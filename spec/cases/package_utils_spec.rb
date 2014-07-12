# Copyright (c) 2014 yutopp
# Licenced under the MIT License (http://www.opensource.org/licenses/mit-license.php)
require 'tmpdir'
require_relative '../spec_helper'

describe :package_utils do
  it "test_util" do
    expect(TorigoyaKit::Package::Util.parse_package_name("torigoya-llvm-3.4_3.4_amd64.deb")).to eq ['llvm', '3.4']

    expect(TorigoyaKit::Package::Util.parse_package_name("torigoya-llvm_999.2014.4.4.205650_amd64.deb")).to eq ['llvm', '999.2014.4.4.205650']

    expect do
      TorigoyaKit::Package::Util.parse_package_name("torigababa64.deb")
    end.to raise_error RuntimeError
  end

  it "test_tag_1" do
    tag = TorigoyaKit::Package::Tag.new("torigoya-llvm-3.4_3.4_amd64.deb")
    expect(tag.package_name).to eq "torigoya-llvm-3.4_3.4_amd64.deb"
    expect(tag.name).to eq "llvm"
    expect(tag.version).to eq "3.4"
    expect(tag.display_version).to eq "3.4"
  end

  it "test_tag_j1" do
    tag = TorigoyaKit::Package::Tag.new("torigoya-java9_999.2014.4.8.e912167e7ecf_amd64.deb")
    expect(tag.package_name).to eq "torigoya-java9_999.2014.4.8.e912167e7ecf_amd64.deb"
    expect(tag.name).to eq "java9"
    expect(tag.version).to eq "head"
    expect(tag.display_version).to eq "HEAD-2014.4.8.e912167e7ecf"
  end

  it "test_tag_21" do
    tag = TorigoyaKit::Package::Tag.new("torigoya-llvm_999.2014.4.4.205650_amd64.deb")
    expect(tag.package_name).to eq "torigoya-llvm_999.2014.4.4.205650_amd64.deb"
    expect(tag.name).to eq "llvm"
    expect(tag.version).to eq "head"
    expect(tag.display_version).to eq "HEAD-2014.4.4.205650"
  end

  it "test_tag_22" do
    tag = TorigoyaKit::Package::Tag.new( "torigoya-llvm_888.2014.4.4.205650_amd64.deb" )
    expect(tag.package_name).to eq "torigoya-llvm_888.2014.4.4.205650_amd64.deb"
    expect(tag.name).to eq "llvm"
    expect(tag.version).to eq "dev"
    expect(tag.display_version).to eq "DEV-2014.4.4.205650"
  end

  it "test_tag_23" do
    tag = TorigoyaKit::Package::Tag.new( "torigoya-llvm_777.2014.4.4.205650_amd64.deb" )
    expect(tag.package_name).to eq "torigoya-llvm_777.2014.4.4.205650_amd64.deb"
    expect(tag.name).to eq "llvm"
    expect(tag.version).to eq "stable"
    expect(tag.display_version).to eq "STABLE-2014.4.4.205650"
  end

  it "test_tag_2" do
    expect do
      tag = TorigoyaKit::Package::Tag.new( "torigababa64.deb" )
    end.to raise_error(RuntimeError)
  end

  it "test_prof_update_exist" do
    Dir.mktmpdir do |dir|
      h = TorigoyaKit::Package::ProfileHolder.new( dir )

      p_name = "torigoya-llvm_999.2014.4.4.205650_amd64.deb"
      new_p_time = Time.now()

      begin
        f_path = h.update_package( p_name, new_p_time )

        expect(f_path).to eq "#{dir}/llvm-head.yml"
        expect(File.exists?(f_path)).to eq true
      end
    end # Dir
  end

  it "test_prof_update" do
    Dir.mktmpdir do |dir|
      h = TorigoyaKit::Package::ProfileHolder.new( dir )

      p_name = "torigoya-llvm_999.2014.4.4.205650_amd64.deb"
      new_p_time = Time.now()
      updated_p_time = new_p_time + 100

      begin
        f_path = h.update_package( p_name, new_p_time )

        expect(File.exists?(f_path)).to eq true
        f_y = TorigoyaKit::Package::AvailableProfile.load_from_yaml(f_path)
        expect(f_y.package_name).to eq p_name
        expect(f_y.built_date).to eq new_p_time
      end

      begin
        # Latest File
        f_path = h.update_package(p_name, updated_p_time)

        expect(File.exists?( f_path )).to eq true
        f_y = TorigoyaKit::Package::AvailableProfile.load_from_yaml(f_path)
        expect(f_y.package_name).to eq p_name
        expect(f_y.built_date).to eq updated_p_time
      end

      begin
        f_path = h.update_package(p_name, new_p_time)

        expect(File.exists?(f_path)).to eq true
        f_y = TorigoyaKit::Package::AvailableProfile.load_from_yaml(f_path)
        expect(f_y.package_name).to eq p_name
        expect(f_y.built_date).to eq updated_p_time
      end
    end # Dir
  end

  it "test_prof_delete" do
    Dir.mktmpdir do |dir|
      h = TorigoyaKit::Package::ProfileHolder.new(dir)

      p_name = "torigoya-llvm_999.2014.4.4.205650_amd64.deb"
      new_p_time = Time.now()

      begin
        f_path = h.update_package(p_name, new_p_time)
        expect(File.exists?(f_path)).to eq true
      end

      begin
        f_path = h.delete_package(p_name)
        expect(File.exists?(f_path)).to eq false
      end
    end # Dir
  end

  it "test_prof_list" do
    Dir.mktmpdir do |dir|
      h = TorigoyaKit::Package::ProfileHolder.new(dir)

      build_date = Time.now
      pkgs = [{ name: "torigoya-llvm-3.4_3.4_amd64.deb", date: build_date },
              { name: "torigoya-llvm_999.2014.4.4.205650_amd64.deb", date: build_date },
             ]

      begin
        pkgs.each do |e|
          h.update_package(e[:name], e[:date])
        end
      end

      begin
        profs = h.list_profiles

        expect(profs.length).to eq 2
        #expect(profs[0].package_name).to eq pkgs[0][:name]
        expect(profs[0].built_date).to eq pkgs[0][:date]
        #expect(profs[1].package_name).to eq pkgs[1][:name]
        expect(profs[1].built_date).to eq pkgs[1][:date]
      end
    end # Dir
  end
end

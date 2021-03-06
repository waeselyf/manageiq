require "spec_helper"
require_migration

describe SetCorrectStiTypeOnOpenstackInfraMiqTemplate do
  let(:ext_management_system_stub) { migration_stub(:ExtManagementSystem) }
  let(:miq_template_stub) { migration_stub(:Vm) }

  EMS_ROW_ENTRIES = [
    {:type => "ManageIQ::Providers::Openstack::InfraManager"},
    {:type => "ManageIQ::Providers::Openstack::CloudManager"},
    {:type => "ManageIQ::Providers::AnotherManager"}
  ]

  ROW_ENTRIES = [{
                   :ems      => EMS_ROW_ENTRIES[0],
                   :name     => "template_1",
                   :type_in  => 'ManageIQ::Providers::Openstack::CloudManager::Template',
                   :type_out => 'ManageIQ::Providers::Openstack::InfraManager::Template'
                 },
                 {
                   :ems      => EMS_ROW_ENTRIES[0],
                   :name     => "template_2",
                   :type_in  => 'ManageIQ::Providers::Openstack::CloudManager::Template',
                   :type_out => 'ManageIQ::Providers::Openstack::InfraManager::Template'
                 },
                 {
                   :ems      => EMS_ROW_ENTRIES[1],
                   :name     => "template_3",
                   :type_in  => 'ManageIQ::Providers::Openstack::CloudManager::Template',
                   :type_out => 'ManageIQ::Providers::Openstack::CloudManager::Template'
                 },
                 {
                   :ems      => EMS_ROW_ENTRIES[2],
                   :name     => "template_4",
                   :type_in  => 'ManageIQ::Providers::AnyManager::Template',
                   :type_out => 'ManageIQ::Providers::AnyManager::Template'
                 },
  ]

  migration_context :up do
    it "migrates a series of representative row" do
      EMS_ROW_ENTRIES.each do |x|
        x[:ems] = ext_management_system_stub.create!(:type => x[:type])
      end

      ROW_ENTRIES.each do |x|
        x[:miq_template] = miq_template_stub.create!(:type => x[:type_in], :ems_id => x[:ems][:ems].id, :name => x[:name])
      end

      migrate

      ROW_ENTRIES.each do |x|
        expect(x[:miq_template].reload).to have_attributes(
                                      :type   => x[:type_out],
                                      :name   => x[:name],
                                      :ems_id => x[:ems][:ems].id
                                    )
      end
    end
  end

  migration_context :down do
    it "migrates a series of representative row" do
      EMS_ROW_ENTRIES.each do |x|
        x[:ems] = ext_management_system_stub.create!(:type => x[:type])
      end

      ROW_ENTRIES.each do |x|
        x[:miq_template] = miq_template_stub.create!(:type => x[:type_out], :ems_id => x[:ems][:ems].id, :name => x[:name])
      end

      migrate

      ROW_ENTRIES.each do |x|
        expect(x[:miq_template].reload).to have_attributes(
                                             :type   => x[:type_in],
                                             :name   => x[:name],
                                             :ems_id => x[:ems][:ems].id
        )
      end
    end
  end
end

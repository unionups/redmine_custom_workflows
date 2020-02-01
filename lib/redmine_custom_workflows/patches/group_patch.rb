# encoding: utf-8
# frozen_string_literal: true
#
# Redmine plugin for Custom Workflows
#
# Copyright © 2015-19 Anton Argirov
# Copyright © 2019-20 Karel Pičman <karel.picman@kontron.com>
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License
# as published by the Free Software Foundation; either version 2
# of the License, or (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.

module RedmineCustomWorkflows
  module Patches
    module GroupPatch

      def self.included(base)
        base.class_eval do
          before_save :before_save_custom_workflows
          after_save :after_save_custom_workflows
          before_destroy :before_destroy_custom_workflows
          after_destroy :after_destroy_custom_workflows

          def self.users_callback(event, group, user)
            group.instance_variable_set(:@group, group)
            group.instance_variable_set(:@user, user)
            CustomWorkflow.run_shared_code(group) if event.to_s.starts_with? 'before_'
            CustomWorkflow.run_custom_workflows(:group_users, group, event)
          end
          [:before_add, :before_remove, :after_add, :after_remove].each do |observable|
            send("#{observable}_for_users") << if Rails::VERSION::MAJOR >= 4
                                                 lambda { |event, group, user| Group.users_callback(event, group, user) }
                                               else
                                                 lambda { |group, user| Group.users_callback(observable, group, user) }
                                               end
          end
        end
      end

      include RedmineCustomWorkflows::Concerns::CustomFieldsHelpers

      private
        def before_save_custom_workflows
          @group = self
          @saved_attributes = attributes.dup
          CustomWorkflow.run_shared_code(self)
          CustomWorkflow.run_custom_workflows(:group, self, :before_save)
          throw :abort if errors.any?
          errors.empty? && (@saved_attributes == attributes || valid?)
        ensure
          @saved_attributes = nil
        end

        def after_save_custom_workflows
          CustomWorkflow.run_custom_workflows(:group, self, :after_save)
        end

        def before_destroy_custom_workflows
          CustomWorkflow.run_custom_workflows(:group, self, :before_destroy)
        end

        def after_destroy_custom_workflows
          CustomWorkflow.run_custom_workflows(:group, self, :after_destroy)
        end
    end

    module GroupsControllerPatch
      extend ActiveSupport::Concern
      include RedmineCustomWorkflows::Concerns::ControllerPatch     

      included do 
        # after_action :after_edit_action_custom_workflows , only: [:new, :edit]
        private
          def after_action_custom_workflows
            CustomWorkflow.run_custom_workflows(:group, @group, :after_action)
          end

      end
      # class_methods do
        
      # end
    end
  end
end

# Apply patch
RedmineExtensions::PatchManager.register_model_patch 'Group',
  'RedmineCustomWorkflows::Patches::GroupPatch'


RedmineExtensions::PatchManager.register_controller_patch 'GroupsController',
  'RedmineCustomWorkflows::Patches::GroupsControllerPatch'
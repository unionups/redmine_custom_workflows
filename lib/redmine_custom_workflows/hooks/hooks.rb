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

  class Hooks < Redmine::Hook::ViewListener

    def view_layouts_base_html_head(context)
      return if defined?(EasyExtensions)
      "\n".html_safe + stylesheet_link_tag('custom_workflows.css', plugin: :redmine_custom_workflows)
    end

    def easy_extensions_javascripts_hook(context={})
      context[:template].require_asset('tab_override.js')
    end

    def easy_extensions_stylesheets_hook(context={})
      context[:template].require_asset('custom_workflows.css')
    end

  end

end
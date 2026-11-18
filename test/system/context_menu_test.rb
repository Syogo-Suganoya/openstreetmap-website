# frozen_string_literal: true

require "application_system_test_case"

class ContextMenuTest < ApplicationSystemTestCase
  test "context menu stays inside the map when there isn't room above or below the click" do
    original_size = page.current_window.size
    page.current_window.resize_to(640, 360)

    visit "/#map=15/51.76320/-0.00760"

    find_by_id("map").right_click

    within "#map-context-menu" do
      assert_link "Centre map here"
    end

    menu = evaluate_script("document.querySelector('#map-context-menu .dropdown-menu').getBoundingClientRect().toJSON()")
    map = evaluate_script("document.getElementById('map').getBoundingClientRect().toJSON()")

    assert_operator menu["top"], :>=, map["top"]
    assert_operator menu["bottom"], :<=, map["bottom"]
  ensure
    page.current_window.resize_to(*original_size) if original_size
  end

  test "disabled context menu items explain why they are disabled" do
    visit "/#map=11/51.76320/-0.00760"

    find_by_id("map").right_click

    within "#map-context-menu" do
      assert_selector "li[title='Zoom in to add a note to the map'] > a.disabled", :text => "Add a note here"
      assert_selector "li[title='Zoom in to query features'] > a.disabled", :text => "Query features"
      assert_no_selector "li[title]", :text => "Show address"
    end
  end

  test "enabled context menu items have no disabled explanation" do
    visit "/#map=15/51.76320/-0.00760"

    find_by_id("map").right_click

    within "#map-context-menu" do
      assert_link "Query features"
      assert_no_selector "li[title]"
    end
  end
end

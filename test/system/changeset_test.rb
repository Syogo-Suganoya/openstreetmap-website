# frozen_string_literal: true

require "application_system_test_case"

class ChangesetSystemTest < ApplicationSystemTestCase
  test "show existing changeset" do
    changeset = create(:changeset)

    visit changeset_path(changeset)
    within_sidebar do
      assert_text "Changeset: #{changeset.id}"
    end
  end

  test "show error message for a changeset that doesn't exist" do
    visit changeset_path(0)
    within_sidebar do
      assert_text "changeset #0 could not be found"
    end
  end

  test "initialise the sidebar without errors for a changeset that doesn't exist" do
    visit changeset_path(0)
    within_sidebar do
      assert_text "changeset #0 could not be found"
    end

    error = evaluate_async_script <<~JS
      const done = arguments[0];
      OSM.router.load().then(() => done(null), e => done(e.message));
    JS
    assert_nil error
  end
end

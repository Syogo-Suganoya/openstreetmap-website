# frozen_string_literal: true

require "test_helper"

module Notifications
  class DiaryCommentViewTest < ActionView::TestCase
    def test_render
      diary_comment = build_stubbed(:diary_comment)
      notification = build_stubbed(:notification, :record => diary_comment)

      render(
        "notifications/notification",
        :notification => notification
      )

      assert_dom ".web-notification" do
        assert_dom "h2", "Diary comment"
        assert_dom "h2 a", 1 do |links|
          assert_equal diary_entry_path(diary_comment.diary_entry.user, diary_comment.diary_entry), URI.parse(links.first["href"]).path
        end
        assert_dom "time", "less than 1 minute ago"
        assert_dom "blockquote", diary_comment.body
      end
    end

    def test_render_with_long_text
      comment_user = build_stubbed(
        :user,
        :display_name => "Helpful Commenter"
      )
      diary_entry = build_stubbed(:diary_entry)
      diary_comment = build_stubbed(
        :diary_comment,
        :user => comment_user,
        :diary_entry => diary_entry,
        :body => read_fixture_file("lorem_ipsum.txt")
      )
      notification = build_stubbed(:notification, :record => diary_comment)

      render(
        "notifications/notification",
        :notification => notification
      )

      assert_dom ".web-notification blockquote p", :count => 3
    end

    def test_render_hidden_comment
      diary_comment = create(:diary_comment, :body => "Hidden spam", :visible => false)

      render_notification(diary_comment, diary_comment.diary_entry.user)
      assert_not_dom "blockquote"
      assert_dom ".web-notification p", "Unfortunately this is not available any more"

      render_notification(diary_comment, create(:moderator_user))
      assert_dom "blockquote", "Hidden spam"
    end

    def test_render_comment_from_suspended_user
      diary_comment = create(:diary_comment, :user => create(:user, :suspended), :body => "Spam")

      render_notification(diary_comment, diary_comment.diary_entry.user)
      assert_not_dom "blockquote"
    end

    def test_render_comment_on_hidden_entry
      diary_entry = create(:diary_entry, :title => "Hidden title", :visible => false)
      diary_comment = create(:diary_comment, :diary_entry => diary_entry)

      render_notification(diary_comment, create(:user))
      assert_not_dom "a", "Hidden title"
      assert_dom ".web-notification p", "Unfortunately this is not available any more"

      render_notification(diary_comment, diary_entry.user)
      assert_dom "a", "Hidden title"
    end

    def test_render_comment_on_entry_by_deleted_user
      diary_entry = create(:diary_entry, :user => create(:user, :deleted), :title => "Gone title")
      diary_comment = create(:diary_comment, :diary_entry => diary_entry)

      render_notification(diary_comment, create(:moderator_user))
      assert_not_dom "a", "Gone title"
    end

    private

    def render_notification(record, recipient)
      notification = build_stubbed(:notification, :record => record, :recipient => recipient)
      render("notifications/notification", :notification => notification)
    end
  end
end

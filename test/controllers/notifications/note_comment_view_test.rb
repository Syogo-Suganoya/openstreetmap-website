# frozen_string_literal: true

require "test_helper"

module Notifications
  class NoteCommentViewTest < ActionView::TestCase
    def test_render_commented
      note_comment = build_stubbed(
        :note_comment,
        :author => build_stubbed(:user),
        :event => "commented"
      )
      notification = build_stubbed(:notification, :record => note_comment)

      render(
        "notifications/notification",
        :notification => notification
      )

      assert_dom ".web-notification" do
        assert_dom "h2", "Note comment"
        assert_dom "h2 a[href='#{note_path(note_comment.note, :anchor => "c#{note_comment.id}")}']"
        assert_dom "time", "less than 1 minute ago"
        assert_dom "blockquote", note_comment.body
      end
    end

    def test_render_commented_with_long_text
      comment_author = build_stubbed(
        :user,
        :display_name => "Helpful Commenter"
      )
      note = build_stubbed(:note)
      note_comment = build_stubbed(
        :note_comment,
        :author => comment_author,
        :note => note,
        :body => read_fixture_file("lorem_ipsum.txt")
      )
      notification = build_stubbed(:notification, :record => note_comment)

      render(
        "notifications/notification",
        :notification => notification
      )

      assert_dom ".web-notification blockquote p", :count => 3
    end

    def test_render_closed_with_comment
      comment_author = build_stubbed(
        :user,
        :display_name => "Helpful Commenter"
      )
      note = build_stubbed(:note)
      note_comment = build_stubbed(
        :note_comment,
        :author => comment_author,
        :note => note,
        :event => "closed"
      )
      notification = build_stubbed(:notification, :record => note_comment)

      render(
        "notifications/notification",
        :notification => notification
      )

      assert_dom ".web-notification" do
        assert_dom "h2", "Note resolved"
        assert_dom "time", "less than 1 minute ago"
        assert_dom "blockquote", note_comment.body
      end
    end

    def test_render_closed_without_comment
      comment_author = build_stubbed(
        :user,
        :display_name => "Helpful Commenter"
      )
      note = build_stubbed(:note)
      note_comment = build_stubbed(
        :note_comment,
        :author => comment_author,
        :note => note,
        :event => "closed",
        :body => ""
      )
      notification = build_stubbed(:notification, :record => note_comment)

      render(
        "notifications/notification",
        :notification => notification
      )

      assert_dom ".web-notification" do
        assert_dom "h2", "Note resolved"
        assert_dom "time", "less than 1 minute ago"
        assert_not_dom "blockquote"
      end
    end

    def test_render_reopened
      comment_author = build_stubbed(
        :user,
        :display_name => "Helpful Commenter"
      )
      note = build_stubbed(:note)
      note_comment = build_stubbed(
        :note_comment,
        :author => comment_author,
        :note => note,
        :event => "reopened",
        :body => ""
      )
      notification = build_stubbed(:notification, :record => note_comment)

      render(
        "notifications/notification",
        :notification => notification
      )

      assert_dom ".web-notification" do
        assert_dom "h2", "Note reopened"
        assert_dom "time", "less than 1 minute ago"
        assert_not_dom "blockquote"
      end
    end

    def test_render_comment_on_hidden_note
      note = create(:note, :status => "hidden")
      note_comment = create(:note_comment, :note => note, :author => create(:user), :body => "On a hidden note")

      render_notification(note_comment, create(:user))
      assert_not_dom "blockquote"
      assert_dom ".web-notification p", "Unfortunately this is not available any more"

      render_notification(note_comment, create(:moderator_user))
      assert_dom "blockquote", "On a hidden note"
    end

    def test_render_hidden_comment
      note_comment = create(:note_comment, :author => create(:user), :body => "Hidden spam", :visible => false)

      render_notification(note_comment, create(:user))
      assert_not_dom "blockquote"
    end

    def test_render_comment_from_suspended_user
      note_comment = create(:note_comment, :author => create(:user, :suspended), :body => "Spam")

      render_notification(note_comment, create(:moderator_user))
      assert_not_dom "blockquote"
    end

    private

    def render_notification(record, recipient)
      notification = build_stubbed(:notification, :record => record, :recipient => recipient)
      render("notifications/notification", :notification => notification)
    end
  end
end

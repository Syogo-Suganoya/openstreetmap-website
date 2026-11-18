# frozen_string_literal: true

require "test_helper"

class NodesControllerTest < ActionDispatch::IntegrationTest
  ##
  # test all routes which lead to this controller
  def test_routes
    assert_routing(
      { :path => "/node/1", :method => :get },
      { :controller => "nodes", :action => "show", :id => "1" }
    )
  end

  def test_show
    node = create(:node)
    sidebar_browse_check :node_path, node.id, "elements/show"
  end

  def test_show_links_changeset_comment_count
    node = create(:node)
    create_list(:changeset_comment, 2, :changeset => node.changeset)

    get node_path(node)
    assert_response :success
    assert_select "a.changeset_num_comments[href='#{changeset_path(node.changeset)}'][title='2 comments']", :text => "2"
  end

  def test_show_timeout
    node = create(:node)
    with_settings(:web_timeout => -1) do
      get node_path(node)
    end
    assert_response :error
    assert_template :layout => "map"
    assert_dom "h2", "Timeout Error"
    assert_dom "p", /#{Regexp.quote("the node with the id #{node.id}")}/
  end
end

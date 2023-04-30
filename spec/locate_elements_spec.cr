require "./spec_helper"

session = WebdriverSessionHelper.session

##############################################

class ToDoListPageForElementLocators < WebdriverPump::Page
  url "#{WebdriverSessionHelper.base_url}/todo_list.html"

  element :index_link, {locator: {link_text: "index page"}, attribute: "href"}
  element :title, {locator: {xpath: "//div[@role='title']"}}
  element :fill_item, {locator: {xpath: "//input[@role='new_item']"}}

  elements :divs_role, {locator: {tag_name: "div"}, attribute: "role"}
  elements :items, {locator: {xpath: "//span[@role='name']"}}
  elements :items_lambda, {locator: ->{ root.find_child_elements(:xpath, "//span[@role='name']") }}
end

##############################################

describe WebdriverPump do
  it "single element with hash locator" do
    ToDoListPageForElementLocators.new(session).open do |p|
      p.title.displayed?.should be_true
      p.title.class.should eq Selenium::Element
    end
  end

  it "single element with lambda locator" do
    ToDoListPageForElementLocators.new(session).open do |p|
      p.fill_item.displayed?.should be_true
      p.fill_item.class.should eq Selenium::Element
    end
  end

  it "property value from element" do
    expected_url = "#{WebdriverSessionHelper.base_url}/index.html"
    ToDoListPageForElementLocators.new(session).open do |p|
      p.index_link.should eq expected_url
    end
  end

  it "property value from mutiple elements" do
    expected_roles = %w[todo_list title]
    ToDoListPageForElementLocators.new(session).open do |p|
      p.divs_role.should eq expected_roles
    end
  end

  it "multiple elements with hash locator" do
    ToDoListPageForElementLocators.new(session).open do |p|
      p.items.first.displayed?.should be_true
      p.items.class.should eq Array(Selenium::Element)
    end
  end

  it "multiple elements with lambda locator" do
    ToDoListPageForElementLocators.new(session).open do |p|
      p.items_lambda.first.displayed?.should be_true
      p.items_lambda.class.should eq Array(Selenium::Element)
    end
  end
end

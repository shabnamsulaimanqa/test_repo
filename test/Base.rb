$:.unshift File.join(File.dirname(__FILE__),'..','lib')
# This is a base file which contain definition of functions

require 'test/unit'
require "selenium-webdriver"
require 'rubygems'
# require 'ci/reporter/rake/test_unit_loader.rb'
#require 'json'

$ADMIN_USER = "shabnam17+1@gmail.com"
$ADMIN_PASS = "shab1234"

class Test::Unit::TestCase

  def setup
    @driver = Selenium::WebDriver.for :chrome
    @base_url = "https://login.xero.com/"
    @driver.manage.timeouts.implicit_wait = 30
    @verification_errors = []
    @wait = Selenium::WebDriver::Wait.new(:timeout =>30)
    @driver.manage.window.maximize
  end

  def teardown
    @driver.quit
    assert_equal [], @verification_errors
  end

  def home()
    @driver.get(@base_url)
  end

  def login(username, password)
    self.home()
     @driver.manage.timeouts.implicit_wait = 30
#    self.set_text_value('#email', username, true)
#    self.set_text_value('#password', password, true)
#    self.click_when_clickable('#submitButton')
#    self.wait_until_clickable('#main-content')
  end

  def set_text_value(css, value, clear) # use this to set value for any text field
    element = self.wait_until_clickable(css)
    if clear
      element.clear()
      sleep 0.5
    end
    element.send_keys value
  end

  def select_text(css, value) # selects value from any select drop down
    select = Selenium::WebDriver::Support::Select.new((@driver.find_element(:css, css)))
    select.select_by(:text, value)
  end

  def click_when_clickable(css)
      element = self.wait_until_clickable(css)
      element.click()
  end

def wait_until_clickable(css)
    element = nil
    if css.instance_of?(String)
      if @wait.until{@driver.find_element(:css, css)}
        element = @driver.find_element(:css, css)
      end
    else
      element = css
    end

    if @wait.until{element.enabled?}
      return self.is_clickable(element)
    else
      false
    end
  end

 
  def click_link_when_clickable(link_text, partial, within)
    element = self.wait_until_link_clickable(link_text, partial, within)
    self.click_when_clickable(element)
  end

  def wait_until_link_clickable(link_text, partial, within)
    if within
      parent = self.wait_until_clickable(within)
    else
      parent = @driver
    end
    if partial
      element = parent.find_element(:partial_link_text, link_text)
    else
      element = parent.find_element(:link_text, link_text)
    end
    return self.wait_until_clickable(element)
  end


  def select_text(css, value) # selects value from any select drop down
    select = Selenium::WebDriver::Support::Select.new((@driver.find_element(:css, css)))
    select.select_by(:text, value)
  end

 def is_clickable(element)
    begin
      return element if element.displayed?
    rescue Selenium::WebDriver::Error::NoSuchElementError => ex
      puts ex.message
      @verification_errors << ex
    end
  end

  def element_present?(how, what)
    @driver.find_element(how, what)
    true
  rescue Selenium::WebDriver::Error::NoSuchElementError
    false
  end
# assert_equal(self.wait_until_clickable('div.inner-content-outer-container-full h2').text, "MY PUBLISHED VIDEOS")
#assert_equal(self.wait_until_clickable('li.videos h1').text, "#{@video_title}")
  def verify(&blk)
    yield
  rescue Test::Unit::AssertionFailedError => ex
    @verification_errors << ex
  end


end

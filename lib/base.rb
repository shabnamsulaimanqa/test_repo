$:.unshift File.join(File.dirname(__FILE__),'..','lib')


require 'test/unit'
require "selenium-webdriver"
require 'rubygems'
require 'ci/reporter/rake/test_unit_loader.rb'
#require 'json'

$ADMIN_USER = "7993832"
$ADMIN_PASS = "tiger"

class Test::Unit::TestCase

  def setup
    #@driver = Selenium::WebDriver.for :firefox
    @driver = Selenium::WebDriver.for :chrome
    @base_url = "https://www.xero.com/signup"
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
    self.set_text_value('#edit-name', username, true)
    self.set_text_value('#edit-pass', password, true)
    self.click_when_clickable('#edit-submit')
    self.wait_until_clickable('#main-content')
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

  def switch_to_iframe()
    @driver.switch_to.frame("iframe_canvas")
    self.wait_until_clickable('#video-owner-info')
    sleep 3
  end

  def wait_for_text(css)
    flag = true
    begin
      while flag
        if self.wait_until_clickable(css).text.eql?("")
          sleep 0.5
        else
          return self.wait_until_clickable(css).text
        end
      end
    end
    rescue
    puts "Exception in wait for text method"
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

  def assert_email(subject)
    begin
      max_attempts = 6
      gmail = Gmail.connect!($PUBLISHER_USER, $PUBLISHER_PASS)
      while max_attempts > 0
        gmail.inbox.search(:subject => subject).each do |email|
          if email.subject.eql?(subject)
            return true
          else
            puts "#{max_attempt} attempt to receive email in 2 seconds"
            max_attempts -= 1
            sleep 2
          end
        end
      end
      puts "email not received in #{max_attempt} attempts"
      return false
    rescue
      puts "Gmail Connect did not work"
    end
  end



  # this method is used to verify links are functional
  # node means where to look for element to verify, mostly it is Title of the page, node_text is Title of the page itself
  def check(link_text, within, node, node_text, new_tab, return_home)
    self.click_link_when_clickable(link_text, false, within)
    if new_tab
      puts "-------- #{@driver.window_handles.inspect}"
      @driver.switch_to.window(@driver.window_handles.last){
        if node
          assert_equal(self.wait_until_clickable(node).text, node_text)
        end
      @driver.close
      }
    else
      if node
        assert_equal(self.wait_until_clickable(node).text, node_text)
      end
      if return_home
        self.home()
        sleep 2 #FIXME
      end
    end
  end

  def wait_until_ajax_ready()
    value = @driver.execute_script("return jQuery.active")
    while value != 0
      sleep 2
      value = @driver.execute_script("return jQuery.active")
    end
  end

  def get_title_row(title)
    elements = @driver.find_elements(:css, "li.process h1")
    i = 0
    while elements.size > i
      if elements[i].text.eql?("#{title}")
        return elements[i]
      else
        i += 1
      end
    end
    puts "#{title} not found on page"
  end

  def get_parent(css)
    element = self.wait_until_clickable(css)
    script = "return arguments[0].parentNode"
    return @driver.execute_script(script, element)
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

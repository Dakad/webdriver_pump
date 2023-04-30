require "selenium"

class WebdriverSessionHelper
  ALLOWED_BROWSER_TYPES = %w(chrome firefox)

  @@session : Selenium::Session | Nil
  @@driver  : Selenium::Driver | Nil

  def self.base_url
    "https://bwilczek.github.io/watir_pump_tutorial"
  end

  def self.session
    @@session ||= begin
      session = driver.not_nil!.create_session(browser_options)

      Spec.after_suite do
        session.window_manager.close_window
        driver.not_nil!.stop
      end

      session
    end
  end

  def self.driver
    @@driver ||= case browser_type
                 when "chrome"
                   driver_path = `which chrome`.chomp
                   driver_service = Selenium::Service.chrome(driver_path: driver_path)
                   Selenium::Driver.for(:chrome, service: driver_service)
                 when "firefox"
                   driver_path = `which geckodriver`.chomp
                   driver_service = Selenium::Service.firefox(driver_path:  driver_path)
                   Selenium::Driver.for(:firefox, service: driver_service)
                 end
  end

  def self.browser_type
    type = ENV.fetch("RUN_ON", "chrome")
    raise "Invalid value for browser_type: #{type} - Allowed values #{ALLOWED_BROWSER_TYPES}" unless ALLOWED_BROWSER_TYPES.includes? type
    type
  end

  def self.browser_options
    capabilities = case browser_type
                   when "firefox"
                     cap = Selenium::Firefox::Capabilities.new
                     cap.firefox_options = firefox_browser_options
                     cap
                   when "chrome"
                     cap = Selenium::Chrome::Capabilities.new
                     cap.chrome_options = chrome_browser_options
                     cap
                   end
    capabilities
  end

  def self.firefox_browser_options
    options = Selenium::Firefox::Capabilities::FirefoxOptions.new
    options.args = ["--safe-mode", "--devtools"]
    options.args << "--headless" if ENV.has_key?("CI")

    if ENV.has_key?("RUN_WITH_PROFILE")
      if profile_name = ENV["BROWSER_PROFILE_NAME"]?
        options.args << "-P #{profile_name}"
      elsif profile_path = ENV["BROWSER_PROFILE_PATH"]?
        options.args << "--profile #{profile_path}"
      else
        raise "Missing BROWSER_PROFILE_NAME or BROWSER_PROFILE_PATH env config"
      end
    end
    options
  end

  def self.chrome_browser_options
    options = Selenium::Chrome::Capabilities::ChromeOptions.new
    options.args = ["no-sandbox", "disable-gpu"]
    options.args << "headless" if ENV.has_key?("CI")
    options
  end
end

require "application_system_test_case"

class SmokeTest < ApplicationSystemTestCase
  # Minimal end-to-end smoke test that validates the test infrastructure:
  #   - The Rails app boots in test env
  #   - Postgres + migrations apply cleanly
  #   - The asset pipeline compiles
  #   - Headless Chrome + Selenium launch and render the page
  #   - Capybara finds DOM content
  #
  # This test is deliberately tolerant of design refactors: it asserts on
  # the brand name in <title>, which is stable across design systems
  # (DaisyUI luxury → Stitch Cinematic Archivist → future iterations).
  test "homepage loads and contains the Vera Trade brand in the title" do
    visit root_path

    assert_title(/Vera Trade/)
  end
end

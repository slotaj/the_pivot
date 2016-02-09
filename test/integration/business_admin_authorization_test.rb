require 'test_helper'

class BusinessAdminAuthorizationTest < ActionDispatch::IntegrationTest
  test "business admin can login" do 
    user = create(:user, role: 1)
    venue = create(:venue)
    concert = create(:concert)
    venue.concerts << concert

    visit login_path
    assert_equal login_path, current_path

    fill_in "session[username]", with: user.username
    fill_in "session[password]", with: user.password

    within('form') do
      click_on("Login")
    end

    assert_equal user_path(user), current_path

    assert page.has_content?(user.username)
    assert page.has_content?("Completed Orders")
    assert page.has_content?("Manage Venues")
  end
  
  test "business admin views homepage" do 
    business_admin = create(:user, role: 1)
    venue = create(:venue, user: business_admin, status: 1)
    concert = create(:concert)
    venue.concerts << concert

    ApplicationController.any_instance.stubs(:current_user).returns(business_admin)

    visit root_path

    assert page.has_content?(venue.name)
    assert page.has_content?(concert.band)
  end

  test "registered user views venue show page" do 
    business_admin = create(:user, role: 1)
    venue = create(:venue, user: business_admin, status: 1)
    concert = create(:concert)
    venue.concerts << concert

    ApplicationController.any_instance.stubs(:current_user).returns(business_admin)
    
    visit venue_path(venue.url)

    assert page.has_content?(venue.name)
    assert page.has_content?(concert.band)
    assert page.has_content?("Edit")
    assert page.has_content?("Remove")
    assert page.has_content?("Add an Admin")
  end 

  test "business admin views venue_concert show page" do 
    business_admin = create(:user, role: 1)
    venue = create(:venue, user: business_admin, status: 1)
    concert = create(:concert)
    venue.concerts << concert

    ApplicationController.any_instance.stubs(:current_user).returns(business_admin)

    visit venue_concert_path(venue.url, concert.url)

    assert page.has_content?(venue.name)
    assert page.has_content?(concert.band)
    assert page.has_content?("Quantity")
  end 

  test "business admin can edit concert" do 
    business_admin = create(:user, role: 1)
    venue = create(:venue, user: business_admin, status: 1)
    concert = create(:concert)
    venue.concerts << concert

    ApplicationController.any_instance.stubs(:current_user).returns(business_admin)

    visit venue_path(venue.url)

    assert page.has_content?(venue.name)
    assert page.has_content?(concert.band)
    assert page.has_content?("Edit")
    assert page.has_content?("Remove")
    
    within('.concert-venue') do 
      click_on("Edit")
    end
    # assert_equal venue_edit_concert_path(concert.venue.url, concert.url), current_path
    fill_in "concert[band]", with: "Ja Rule"
    fill_in "concert[price]", with: 45
    fill_in "concert[genre]", with: "Rap"
    click_on "Update Concert"

    assert_equal venue_path(venue.url), current_path
    assert page.has_content?("Ja Rule")
  end

  test "business admin can remove concert" do 
    business_admin = create(:user, role: 1)
    venue = create(:venue, user: business_admin, status: 1)
    concert = create(:concert)
    venue.concerts << concert

    ApplicationController.any_instance.stubs(:current_user).returns(business_admin)

    visit venue_path(venue.url)

    assert page.has_content?(venue.name)
    assert page.has_content?(concert.band)
    assert page.has_content?("Edit")
    assert page.has_content?("Remove")
    
    within('.concert-venue') do 
      click_on("Remove")
    end

    assert_equal venue_path(venue.url), current_path
    refute page.has_content?(concert.band)
    refute page.has_content?(concert.date)
    refute page.has_content?(concert.logo)
  end 

end

require 'test_helper'

class GuestAddsConcertToCartTest < ActionDispatch::IntegrationTest
  test "registered user adds concert to cart" do
    venue = create(:venue, status: 1)
    concert = create(:concert, venue: venue)
    registered_user = create(:user, role: 0)
    ApplicationController.any_instance.stubs(:current_user).returns(registered_user)

    visit venue_concert_path(concert.venue.url, concert.url)
    assert_equal venue_concert_path(concert.venue.url, concert.url), current_path

    assert page.has_content?(concert.date)
    assert page.has_content?("Logo")
    assert page.has_content?(concert.band)
    assert page.has_content?(concert.venue.name)
    assert page.has_content?(concert.price)
    assert page.has_content?("Quantity")
    assert page.has_content?(concert.category.description.capitalize)

    fill_in "order[quantity]", with: 2

    click_button("Add to Cart")

    assert_equal cart_path, current_path

    assert page.has_content?(concert.date)
    assert page.has_content?("Logo")
    assert page.has_content?(concert.band)
    assert page.has_content?(concert.venue.name)
    assert page.has_content?(concert.price)
    assert page.has_content?("Quantity")
    assert page.has_content?(concert.price)

    assert page.has_content?("2")
    assert page.has_content?("#{concert.price * 2}")
    assert page.has_content?("Checkout!")
  end

  test "unregistered guest adds concert to cart" do
    venue = create(:venue, status: 1)
    concert = create(:concert, venue: venue)

    visit venue_concert_path(concert.venue.url, concert.url)
    assert_equal venue_concert_path(concert.venue.url, concert.url), current_path

    assert page.has_content?(concert.date)
    assert page.has_content?("Logo")
    assert page.has_content?(concert.band)
    assert page.has_content?(concert.venue.name)
    assert page.has_content?(concert.price)
    assert page.has_content?("Quantity")

    fill_in "order[quantity]", with: 2

    click_button("Add to Cart")

    assert_equal cart_path, current_path

    assert page.has_content?(concert.date)
    assert page.has_content?("Logo")
    assert page.has_content?(concert.band)
    assert page.has_content?(concert.venue.name)
    assert page.has_content?(concert.price)
    assert page.has_content?("Quantity")
    assert page.has_content?(concert.price)

    assert page.has_content?("2")
    assert page.has_content?("#{concert.price * 2}")
    assert page.has_content?("Create account to checkout")
  end

  test "registered user can purchase tickets" do
    venue = create(:venue, status: 1)
    concert = create(:concert, venue: venue)
    registered_user = create(:user, role: 0)
    ApplicationController.any_instance.stubs(:current_user).returns(registered_user)

    visit venue_concert_path(concert.venue.url, concert.url)
    assert_equal venue_concert_path(concert.venue.url, concert.url), current_path

    assert page.has_content?(concert.date)
    assert page.has_content?("Logo")
    assert page.has_content?(concert.band)
    assert page.has_content?(concert.venue.name)
    assert page.has_content?(concert.price)
    assert page.has_content?("Quantity")

    fill_in "order[quantity]", with: 2

    click_button("Add to Cart")

    assert_equal cart_path, current_path

    assert page.has_content?(concert.date)
    assert page.has_content?("Logo")
    assert page.has_content?(concert.band)
    assert page.has_content?(concert.venue.name)
    assert page.has_content?(concert.price)
    assert page.has_content?("Quantity")
    assert page.has_content?(concert.price)

    assert page.has_content?("2")
    assert page.has_content?("#{concert.price * 2}")
    assert page.has_content?("Checkout!")

    click_link ("Checkout!")
    assert_equal current_path, new_order_path

    assert page.has_content?("Checkout")
    assert page.has_content?("Please enter an email address for your electronic tickets")
    fill_in "order[address]", with: "jorge@turing.io"
    click_button("Checkout")
  end

  test "registered guest can view ticket history" do
    venue = create(:venue)
    concert = create(:concert, venue: venue)
    registered_user = create(:user, role: 0)
    ApplicationController.any_instance.stubs(:current_user).returns(registered_user)
    order = create(:order)
    order.update(user_id: registered_user.id)
    concert_order = create(:concert_order)
    concert_order.update(concert_id: concert.id, order_id: order.id)

    visit user_path(registered_user.id)

    assert page.has_content?(concert.band)
    assert page.has_content?("1")
    assert page.has_content?(venue.name)
  end

  test "business admin can view ticket history" do
    venue = create(:venue)
    concert = create(:concert, venue: venue)
    registered_user = create(:user, role: 1)
    ApplicationController.any_instance.stubs(:current_user).returns(registered_user)
    order = create(:order)
    order.update(user_id: registered_user.id)
    concert_order = create(:concert_order)
    concert_order.update(concert_id: concert.id, order_id: order.id)

    visit user_path(registered_user.id)

    assert page.has_content?(concert.band)
    assert page.has_content?("1")
    assert page.has_content?(venue.name)
  end

  test "platform admin can view ticket history" do
    venue = create(:venue)
    concert = create(:concert, venue: venue)
    registered_user = create(:user, role: 2)
    ApplicationController.any_instance.stubs(:current_user).returns(registered_user)
    order = create(:order)
    order.update(user_id: registered_user.id)
    concert_order = create(:concert_order)
    concert_order.update(concert_id: concert.id, order_id: order.id)

    visit user_path(registered_user.id)

    assert page.has_content?(concert.band)
    assert page.has_content?("1")
    assert page.has_content?(venue.name)
  end

  test "platform admin receives email confirmation" do
    platform_admin = create(:user, role: 2)
    user = create(:user)
    venue = create(:venue, user_id: user.id, status: 1)
    concert = create(:concert, venue: venue)
    ApplicationController.any_instance.stubs(:current_user).returns(platform_admin)

    visit venue_concert_path(concert.venue.url, concert.url)
    assert_equal venue_concert_path(concert.venue.url, concert.url), current_path

    assert page.has_content?(concert.date)
    assert page.has_content?("Logo")
    assert page.has_content?(concert.band)
    assert page.has_content?(concert.venue.name)
    assert page.has_content?(concert.price)
    assert page.has_content?("Quantity")

    fill_in "order[quantity]", with: 2
    click_button("Add to Cart")

    assert_equal cart_path, current_path

    assert page.has_content?(concert.date)
    assert page.has_content?("Logo")
    assert page.has_content?(concert.band)
    assert page.has_content?(concert.venue.name)
    assert page.has_content?(concert.price)
    assert page.has_content?("Quantity")
    assert page.has_content?(concert.price)

    assert page.has_content?("2")
    assert page.has_content?("#{concert.price * 2}")
    assert page.has_content?("Checkout!")

    click_link ("Checkout!")
    assert_equal current_path, new_order_path

    assert page.has_content?("Checkout")
    assert page.has_content?("Please enter an email address for your electronic tickets")
    fill_in "order[address]", with: platform_admin.username
    click_button("Checkout")
    assert admin_user_path(platform_admin.id), current_path
  end

  test "business admin receives email confirmation" do
    business_admin = create(:user, role: 1)
    user = create(:user)
    venue = create(:venue, user_id: user.id, status: 1)
    concert = create(:concert, venue: venue)
    ApplicationController.any_instance.stubs(:current_user).returns(business_admin)

    visit venue_concert_path(concert.venue.url, concert.url)
    assert_equal venue_concert_path(concert.venue.url, concert.url), current_path

    assert page.has_content?(concert.date)
    assert page.has_content?("Logo")
    assert page.has_content?(concert.band)
    assert page.has_content?(concert.venue.name)
    assert page.has_content?(concert.price)
    assert page.has_content?("Quantity")

    fill_in "order[quantity]", with: 2
    click_button("Add to Cart")

    assert_equal cart_path, current_path

    assert page.has_content?(concert.date)
    assert page.has_content?("Logo")
    assert page.has_content?(concert.band)
    assert page.has_content?(concert.venue.name)
    assert page.has_content?(concert.price)
    assert page.has_content?("Quantity")
    assert page.has_content?(concert.price)

    assert page.has_content?("2")
    assert page.has_content?("#{concert.price * 2}")
    assert page.has_content?("Checkout!")

    click_link ("Checkout!")
    assert_equal current_path, new_order_path

    assert page.has_content?("Checkout")
    assert page.has_content?("Please enter an email address for your electronic tickets")
    fill_in "order[address]", with: business_admin.username
    click_button("Checkout")
    assert admin_user_path(business_admin.id), current_path
  end

  test "registered user removes concert from cart" do
    venue = create(:venue, status: 1)
    concert = create(:concert, venue: venue)
    registered_user = create(:user, role: 0)
    ApplicationController.any_instance.stubs(:current_user).returns(registered_user)

    visit venue_concert_path(concert.venue.url, concert.url)
    assert_equal venue_concert_path(concert.venue.url, concert.url), current_path

    assert page.has_content?(concert.date)
    assert page.has_content?("Logo")
    assert page.has_content?(concert.band)
    assert page.has_content?(concert.venue.name)
    assert page.has_content?(concert.price)
    assert page.has_content?("Quantity")

    fill_in "order[quantity]", with: 2

    click_button("Add to Cart")

    assert_equal cart_path, current_path

    assert page.has_content?(concert.date)
    assert page.has_content?("Logo")
    assert page.has_content?(concert.band)
    assert page.has_content?(concert.venue.name)
    assert page.has_content?(concert.price)
    assert page.has_content?("Quantity")
    assert page.has_content?(concert.price)

    click_on("remove")

    assert page.has_content?("Successfully removed")

    assert_equal cart_path, current_path

    click_on("Checkout!")

    assert page.has_content?("Cart cannot be empty at checkout.")
  end

   test "can't add concert to cart if quantity zero" do
    venue = create(:venue, status: 1)
    concert = create(:concert, venue: venue)
    registered_user = create(:user, role: 0)
    ApplicationController.any_instance.stubs(:current_user).returns(registered_user)

    visit venue_concert_path(concert.venue.url, concert.url)
    assert_equal venue_concert_path(concert.venue.url, concert.url), current_path

    assert page.has_content?(concert.date)
    assert page.has_content?("Logo")
    assert page.has_content?(concert.band)
    assert page.has_content?(concert.venue.name)
    assert page.has_content?(concert.price)
    assert page.has_content?("Quantity")

    fill_in "order[quantity]", with: 0

    click_on("Add to Cart")
    assert_equal cart_path, current_path
  end
end

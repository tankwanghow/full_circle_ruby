require 'spec_helper'

feature 'Login' do
  background do
    create :user, username: 'first'
    create :user, username: 'bob'
    create :active_user, username: 'john', name: 'Johnson Sue'
  end

  scenario "Signing in with incorrect credentials" do
    visit('/login')
    fill_in 'Username', :with => 'user'
    fill_in 'Password', :with => 'wrong'
    click_button 'Login'
    expect(page).to have_selector('.alert-error', text: 'Invalid')
  end

  scenario "Signing in with correct credentials and user is inactive" do
    visit('/login')
    fill_in 'Username', :with => 'bob'
    fill_in 'Password', :with => 'secret'
    click_button 'Login'
    expect(page).to have_selector('.alert-notice', text: 'Pending')
  end

  scenario "Signing in with correct credentials and user is active" do
    visit('/login')
    fill_in 'Username', :with => 'john'
    fill_in 'Password', :with => 'secret'
    click_button 'Login'
    expect(current_path).to eq root_path
    expect(page).to have_selector('.alert-success', text: 'success')
    expect(page).to have_selector('.brand', text: 'Kim Poh Sitt Tat Feedmill Sdn. Bhd.')
    expect(page).to have_selector('a', text: 'Johnson Sue')
  end

end

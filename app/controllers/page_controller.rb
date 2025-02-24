class PageController < ApplicationController
  include RestrictedAccess
  def index
    @books = Book.all.order(created_at: :desc)
  end
end

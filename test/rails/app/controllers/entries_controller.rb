class EntriesController < ApplicationController
  def edit
    @entry = Entry.new
  end
end

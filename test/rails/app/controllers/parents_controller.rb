class ParentsController < ApplicationController
  # GET /parents
  # GET /parents.xml
  def index
    @parents = Parent.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @parents }
    end
  end

  # GET /parents/1
  # GET /parents/1.xml
  def show
    @parent = Parent.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @parent }
    end
  end

  # GET /parents/new
  # GET /parents/new.xml
  def new
    @parent = Parent.new
    @parent.children.build

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @parent }
    end
  end

  # GET /parents/1/edit
  def edit
    @parent = Parent.find(params[:id])
  end

  # POST /parents
  # POST /parents.xml
  def create
    @parent = Parent.new(params[:parent])

    respond_to do |format|
      if @parent.save
        format.html { redirect_to(@parent, :notice => 'Parent was successfully created.') }
        format.xml  { render :xml => @parent, :status => :created, :location => @parent }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @parent.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /parents/1
  # PUT /parents/1.xml
  def update
    @parent = Parent.find(params[:id])

    respond_to do |format|
      if @parent.update_attributes(params[:parent])
        format.html { redirect_to(@parent, :notice => 'Parent was successfully updated.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @parent.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /parents/1
  # DELETE /parents/1.xml
  def destroy
    @parent = Parent.find(params[:id])
    @parent.destroy

    respond_to do |format|
      format.html { redirect_to(parents_url) }
      format.xml  { head :ok }
    end
  end
end

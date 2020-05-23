class FoamrequestsController < ApplicationController

  def new_foam_request_index
    puts "STEP1111111111111111"
    @actu_step = 1
    @customer_groups = Vevocsoport.all
  end


  def choose_foaming_machine
    puts "STEP22222222222222222"
    puts  params[:labelcheck][:customer]
    if params[:labelcheck][:customer].blank?
      puts "emmmpty"
      flash.now[:danger] = "Vevőcsoport kiválasztása kötelező!"
      @actu_step = 1
      @customer_groups = Vevocsoport.all
    else
      @actu_step = 2
    end
    respond_to do |format|
      format.js { render partial: 'request_foam' }
    end    
  end

end
class CustomersController < ApplicationController

  def search
    if params[:labelcheck][:customer].blank?
      flash.now[:danger] = "Vevőcsoport kiválasztása kötelező!"
    else
      @deliveries = ODLN.search_from_lookup(params[:labelcheck][:customer])
      if @deliveries == nil
      #@deliveries = params[:labelcheck][:customer]
        flash.now[:danger] = "Az adott vevőcsoportnak nincsenek nyitott szállításai!"
      end  
    end
    @step2 = false
    respond_to do |format|
      format.js { render partial: 'labelchecks/deliveries' }
    end
  end

  def choose
    @step2 = true
    if params[:deliveries].blank?
      flash.now[:danger] = "Legalább 1 szállítólevél kiválasztása kötelező!"
      respond_to do |format|
        format.js { render partial: 'labelchecks/deliveries' }
      end
    else
      @choosen_deliveries = params[:deliveries]
      @master_labels = []
      @choosen_deliveries.each do |row|
        @masters = MOS_OWSD.search_master_labels(row)
        if @masters != nil
          @masters.each do |label|
            @master_labels.push(label["U_raklap2"])
          end  
        end
      end 
      render :js => "window.location = '#{labelcheck_check_path(:labels => @master_labels)}'"
    end
  end

end
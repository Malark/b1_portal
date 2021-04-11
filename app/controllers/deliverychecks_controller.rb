class DeliverychecksController < ApplicationController

  def check_delivery_index
    @actu_step = 1
    @customer_groups = Vevocsoport.all
  end


  def choose_customer_group
    if params[:customer_group].blank?
      flash.now[:danger] = "Vevőcsoport kiválasztása kötelező!"
      @actu_step = 1
      @customer_groups = Vevocsoport.all
    else
      @actu_step = 2
      @deliveries = ODLN.search_from_lookup(params[:customer_group])
      if @deliveries == nil
        @actu_step = 1
        @customer_groups = Vevocsoport.all
        flash.now[:danger] = "Az adott vevőcsoportnak nincsenek nyitott szállításai!"
      else
        $coosen_customer_group =  params[:customer_group]
      end  
    end
    respond_to do |format|
      format.js { render partial: 'check_deliveries' }
    end
  end  


  def choose_deliveries
    if params[:deliveries].blank?
      @actu_step = 2
      @deliveries = ODLN.search_from_lookup($coosen_customer_group)
      flash.now[:danger] = "Legalább 1 szállítólevél kiválasztása kötelező!"
    else
      @actu_step = 3
      @choosen_deliveries = params[:deliveries]
      $choosen_delivery_notes = @choosen_deliveries
      $master_labels = []
      @choosen_deliveries.each do |row|
        @masters = MOS_OWSD.search_master_labels(row)
        if @masters != nil
          @masters.each do |label|
            $master_labels.push(label["U_raklap2"])
            $checkable_labels.push(label["U_raklap2"])
          end  
        end
      end 
      puts $master_labels
      $checked_labels = []
      @all_labels = $master_labels.length()
      @checked_labels = $checked_labels.length()
      
    end
    respond_to do |format|
      format.js { render partial: 'check_deliveries' }
    end
  end


  def check_labels
    @actu_step = 3
    if params[:labelcheck22].blank?
      flash.now[:danger] = "Nem adott meg érvényes vonalkódot!"
    else
      label = params[:labelcheck22]
      #In case of AUDI (label example: 6JUN364740217000070179)
      if label.length == 22 
        label = (label[13,label.length-1]).to_i.to_s
      else  #Volvo, Daimler, BMW  (label example: M77079)
        if label.length > 1 
          label = label[1,label.length-1]
        end
      end
      if checkable_label(label)
        $checked_labels.push(label)    
        $checkable_labels.delete(label)
      else
        #Check if it was earlier checked
        if checked_label(label)
          flash.now[:danger] = "Már korábban ellenőrzött címke: #{label}"
        else
          flash.now[:danger] = "A(z) #{label} sorszámú címke nem található!"
        end
      end
    end
    @all_labels = $master_labels.length()
    @checked_labels = $checked_labels.length()    
    if @checked_labels >= @all_labels
      #When all the labels are checked
      @actu_step = 4
      write_data
      @result_text = "Ellenőrzött raklapok száma: #{@all_labels}!  Ellenőrzött szállítás(ok): #{$choosen_delivery_notes}"
    end 

    respond_to do |format|
      format.js { render partial: 'check_deliveries' }
    end
  end

  def write_data
    #puts "Update database for checked records"
    MOS_OWSD.update_checked_labels($checked_labels, current_user.username)
  end


  private 

    def checkable_label(label)
      if $checkable_labels.include?(label)  
        return true
      else
        return false
      end
    end

    def checked_label(label)
      if $checked_labels.include?(label) 
        return true
      else
        return false
      end
    end

end
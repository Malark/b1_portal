class InventoryrequestsController < ApplicationController

  Label = Struct.new(:itemcode, :quantity, :prod_date, :prod_time, :package_unit, :package_type, :packager_id, :qainspector_id, :charge_nr)

  def inventory_request_index
    @actu_step = 1
  end

  def check_internal_label_ir
    puts 'EEEEEEEEEEEEEEEEEEEEEEEEEEEEEE'
    if params[:internal_label].blank?
      @actu_step = 1
      flash.now[:danger] = "A belső címke QR kódja nem lehet üres!"
    else
      #With String manipulation get the data form the barcode
      # Test QR code: 14032V2;125;M;200422143021;053;Standard;2020.04.22;14:30:21;csomagolt
      # positions:        0  ; 1 ;2;      3     ; 4 ;    5   ;     6    ;    7   ;    8
      internal_label = params[:internal_label]
      values = internal_label.split(";")
      if values.count < 9
        puts "bell\a"
        @actu_step = 1
        flash.now[:danger] = "Hibás QR kód struktúra!"
      else

      end
    end  

    respond_to do |format|
      format.js { render partial: 'inventory_requests' }
    end      
  end    
end
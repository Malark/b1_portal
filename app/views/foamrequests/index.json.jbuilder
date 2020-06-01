json.foamrequests do
  json.array!(@foamrequests_search) do |req|
    json.search_sugesstion "Gép: #{reg.U_GEP_ID} <br>Termék cikszám: #{reg.U_FOCIKKSZAM} <br>Habrendszer: #{req.U_HABRENDSZER} "
    #json.url cost_path(cost.id)
    json.url edit_foamrequest_path(req)
  end
end
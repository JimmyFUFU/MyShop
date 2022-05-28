function removeItem(pid) {
  $.ajax({
    type: 'DELETE',
    data: JSON.stringify({ product_id: pid }),
    contentType: 'application/json',
    url: `/carts/item.json`,
    success: function(data) {
      $(`#item_${pid}`).hide();
      alertify.success(data.message);
      cartReload()
    },
    error: function(data) {
      alertify.error(data.responseJSON?.error);  
    }
  })
}

function cartReload() {
  $.ajax({
    type: 'GET',
    contentType: 'application/json',
    url: `/carts.json`,
    success: function(data) {
      $('#total-price').text(data.total_price)
    },
    error: function(data) {
      alertify.error(data.responseJSON?.error);  
    }
  })
}
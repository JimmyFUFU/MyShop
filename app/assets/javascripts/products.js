 function minusQuantity(pid) {
  originQuantity = parseInt($(`div#pid-${pid} input.quantity`).val())
  if (originQuantity > 1) {
    $(`div#pid-${pid} input.quantity`).val(--originQuantity)
  }
 }

function plusQuantity(pid, inventory) {
  originQuantity = parseInt($(`div#pid-${pid} input.quantity`).val())
  if (originQuantity < inventory) {
    $(`div#pid-${pid} input.quantity`).val(++originQuantity)
  }
}

function checkQuantity(pid, inventory) {
  originQuantity = parseInt($(`div#pid-${pid} input.quantity`).val())
  if (originQuantity > inventory) {
    $(`div#pid-${pid} input.quantity`).val(inventory)
  }
}

function addToCart(pid) {
  $.ajax({
    type: 'POST',
    data: JSON.stringify({
      product_id: pid,
      quantity: parseInt($(`div#pid-${pid} input.quantity`).val()),
    }),
    contentType: 'application/json',
    url: '/cart/item.json',
    success: function(data) {
      alertify.success(data.message);  
    },
    error: function(data) {
      alertify.error(data.responseJSON?.error);  
    }
  })
}
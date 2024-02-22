window.onload = function() {
  addDeleteEvent();
  addSumFeeEvent();
  if (window.location.pathname.includes('edit')) {
    sumFee();
  };
};

// new edit 行(フォーム)追加
let i = document.getElementById('payment_table').rows.length;
const addButton = document.getElementById('addButton');
addButton.addEventListener('click', function() {
  const table = document.getElementById('payment_table');
  const row = table.insertRow(-1);
  row.classList.add('payment_row');
  const cell_participant = row.insertCell(-1);
  const cell_ratio = row.insertCell(-1);
  const cell_fee = row.insertCell(-1);
  const cell_isPaid = row.insertCell(-1);
  const cell_delete = row.insertCell(-1);

  let nameForm = `
    <label class=payment_label for=payment_payment_details_attributes_${i}_participant>名前</label>
    <input type=text class=form-control
    name=payment[payment_details_attributes][${i}][participant]
    id=payment_payment_details_attributes_${i}_participant>`;
  let ratioForm = `
    <select class=form-select>
      <optgroup label="多い"></optgroup>
      <option value="5">5</option>
      <option value="4">4</option>
      <option value="3" selected>3</option>
      <option value="2">2</option>
      <option value="1">1</option>
      <optgroup label="少ない"></optgroup>
      <hr>
      <option value="0">請求なし</option>
    </select>`;
  let feeForm = `
    <label class=payment_label for=payment_payment_details_attributes_${i}_fee>支払額</label>
    <input class="payment_fee_form form-control" type=number value=0
    name=payment[payment_details_attributes][${i}][fee]
    id=payment_payment_details_attributes_${i}_fee>`;
  let isPaid = `
    <label class=payment_label for=payment_payment_details_attributes_${i}_is_paid>支払済</label>
    <input name=payment[payment_details_attributes][${i}][is_paid] type=hidden value=0 autocomplete=off>
    <input type=checkbox value=1 name=payment[payment_details_attributes][${i}][is_paid] id=payment_payment_details_attributes_${i}_is_paid>`
  let deleteButton = `<button type="button" class="deleteButton"><i class="fa-solid fa-trash" style="color: #757070;"></i></button>`;
  cell_participant.innerHTML = nameForm;
  cell_ratio.innerHTML = ratioForm;
  cell_fee.innerHTML = feeForm;
  cell_isPaid.innerHTML = isPaid;
  cell_delete.innerHTML = deleteButton;

  addDeleteEvent();
  addSumFeeEvent();
  i++ ;
});

// new edit 行(フォーム)削除
function addDeleteEvent() {
  const deleteButton = document.querySelectorAll('.deleteButton');
  deleteButton.forEach(function(button) {
    button.addEventListener('click', hiddenRow);
  });
};

function hiddenRow() {
  const row = this.closest('tr');
  row.style.display = 'none';
  row.className = 'payment_row_hidden';
  // update時にaccepts_nested_attributes_forでDBレコード削除のため_destroy属性を追加
  let i = row.rowIndex - 1;
  let deleteAttribute = `
    <input value="true"
    type="hidden"
    name="payment[payment_details_attributes][${i}][_destroy]"
    id="payment_payment_details_attributes_${i}__destroy"></input>`;
  row.innerHTML += deleteAttribute;
  sumFee();
};

//new edit 支払額計算・表示
const calcButton = document.getElementById('calcButton');
calcButton.addEventListener('click', function() {
  let roundSelect = '';
  let totalRatio = 0;
  let amount = document.getElementById('payment_amount').value;

  let elem = document.getElementsByName('round');
  for (let i = 0; i < elem.length; i++) {
    if (elem[i].checked) {
      roundSelect = elem[i].value;
      break;
    };
  };

  let row = document.querySelectorAll('.payment_row');
  row.forEach(function(row) {
    let select = row.querySelector('select').value;
    totalRatio += parseInt(select);
  });
  row.forEach(function(row) {
    let ratio = row.querySelector('select').value;
    let feeForm = row.querySelector('.payment_fee_form');
    let fee = amount * (ratio / totalRatio);
    switch(roundSelect){
      case 'default' :
        feeForm.value = Math.round(fee);
        break;
      case '100yen' :
        feeForm.value = Math.round(fee / 100) * 100;
        break;
      case '500yen' :
        feeForm.value = Math.round(fee / 500) * 500;
        break;
    };
  });
  sumFee();
});

// new edit　各メンバーの支払額合計・イベント総額に対する差額表示
function addSumFeeEvent() {
  let row = document.querySelectorAll('.payment_row');
  row.forEach(function(row) {
    let feeForm = row.querySelector('.payment_fee_form');
    feeForm.addEventListener('change', sumFee);
  });
};

function sumFee() {
  let totalFee = 0;
  let row = document.querySelectorAll('.payment_row');
  let amount = document.getElementById('payment_amount').value;
  row.forEach(function(row) {
    let select = row.querySelector('.payment_fee_form').value;
    totalFee += parseInt(select) || 0;
  });
  document.getElementById('sum_fee').innerHTML = totalFee;
  document.getElementById('diff_fee').innerHTML = amount - totalFee;
};

// new edit 行(フォーム)追加
let i = document.getElementById('payment_table').rows.length;
const addButton = document.getElementById('addButton');

addButton.addEventListener('click', function() {
  const table = document.getElementById('payment_table');
  const row = table.insertRow(-1);
  const cell_participant = row.insertCell(-1);
  const cell_fee = row.insertCell(-1);
  const cell_delete = row.insertCell(-1);

  let nameForm = `
    <label class=payment_label for=payment_payment_details_attributes_${i}_participant>名前</label>
    <input type=text
    name=payment[payment_details_attributes][${i}][participant]
    id=payment_payment_details_attributes_${i}_participant>`;
  let feeForm = `
    <label class=payment_label for=payment_payment_details_attributes_${i}_fee>支払額</label>
    <input type=number value=0
    name=payment[payment_details_attributes][${i}][fee]
    id=payment_payment_details_attributes_${i}_fee>`;
  let deleteButton = `<span class="deleteButton">削除</span>`;
  cell_participant.innerHTML = nameForm;
  cell_fee.innerHTML = feeForm;
  cell_delete.innerHTML = deleteButton;

  addDeleteEvent();
  i++ ;
});

// new edit 行(フォーム)削除
addDeleteEvent();
function addDeleteEvent() {
  let deleteButton = document.querySelectorAll('.deleteButton');
  deleteButton.forEach(function(button) {
    if (window.location.pathname.includes('/new')) button.addEventListener('click', removeRow);
    if (window.location.pathname.includes('/edit')) button.addEventListener('click', hiddenRow);
  });
};

function removeRow() {
  const row = this.closest('tr');
  row.remove();
};

function hiddenRow() {
  const row = this.closest('tr');
  row.style.display = 'none';
  // accepts_nested_attributes_forでレコード削除のため_destroy属性を追加
  let i = row.rowIndex - 1;
  let deleteAttribute = `
    <input value="true"
    type="hidden"
    name="payment[payment_details_attributes][${i}][_destroy]"
    id="payment_payment_details_attributes_${i}__destroy"></input>`;
  row.innerHTML += deleteAttribute;
};

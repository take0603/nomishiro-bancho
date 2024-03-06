window.onload = function() {
  addDeleteEvent();
};

window.addEventListener('popstate', function() {
  location.reload();
});

// new edit　候補日フォーム追加
let i = document.getElementById('schedule_table').rows.length;
const addButton = document.getElementById('addScheduleForm');
addButton.addEventListener('click', function() {
  const table = document.getElementById('schedule_table');
  const row = table.insertRow(-1);
  row.classList.add('schedule_row');
  const cell_schedule = row.insertCell(-1);
  const cell_delete = row.insertCell(-1);

  let scheduleForm = `
    <input type=datetime-local
    class="form-control"
    name=event[schedules_attributes][${i}][schedule_date]
    id=event_schedules_attributes_${i}_schedule_date>`;
  let deleteButton = `
    <button type="button" class="deleteScheduleForm">
      <i class="fa-solid fa-trash" style="color: #757070;"></i>
    </button>`;
  cell_schedule.innerHTML = scheduleForm;
  cell_delete.innerHTML = deleteButton;
  addDeleteEvent();
  i++ ;
});

// new edit　候補日フォーム削除
function addDeleteEvent() {
  const deleteButton = document.querySelectorAll('.deleteScheduleForm');
  deleteButton.forEach(function(button) {
    button.addEventListener('click', hiddenRow);
  });
};

function hiddenRow() {
  const row = this.closest('tr');
  row.style.display = 'none';
  row.className = 'schedule_row_hidden';

  // update時にaccepts_nested_attributes_forでDBレコード削除のため_destroy属性を追加
  let i = row.rowIndex;
  let deleteAttribute = `
    <input value=true
    type=hidden
    name=event[schedules_attributes][${i}][_destroy]
    id=event_schedules_attributes_${i}__destroy></input>`;
  row.innerHTML += deleteAttribute;
};

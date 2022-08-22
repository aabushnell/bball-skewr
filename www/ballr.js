$(function() {
  $("#player_name").selectize({
    selectOnTab: true,
    maxOptions: 5000,
    onDropdownOpen: function() {
      this.clear('silent');
    }
  });
});

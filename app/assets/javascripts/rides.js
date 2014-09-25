//# Place all the behaviors and hooks related to the matching controller here.
//# All this logic will automatically be available in application.js.
//# You can use CoffeeScript in this file: http://coffeescript.org/
//$ ->
//  $(document).on 'click', 'tr[data-link]', (evt) ->
//    window.location = this.dataset.link

$(document).ready(function () {
    $("#new_ride").validate({
        debug: false,
        focusInvalid: true,
        errorClass: "error",
        validClass:"valid",
        highlight: function(element, errorClass) {
            $(".error").hidden="false";
            $(element).fadeOut(function() {
                $(element).fadeIn();
            });
        },
        rules: {
            "ride[departure_place]": {required: true},
            "ride[destination]": {required: true},
            "ride[departure_time]": {required: true},
            "ride[free_seats]": {required: true},
            "ride[car]": {required: true},
            "ride[meeting_point]": {required: true}
        },
        errorPlacement: function(error, element) {
            error.insertBefore(element);
        },
        messages: {
            "ride[departure_place]": "Please specify departure place",
            "ride[destination]": "Please specify destination place",
            "ride[departure_time]": "Please specify departure time",
            "ride[free_seats]": "Please specify number of free seats",
            "ride[car]": "Please specify car" ,
            "ride[meeting_point]": "Please specify meeting point"
        }
    });
});
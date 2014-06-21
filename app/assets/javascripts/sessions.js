
$(document).ready(function () {



    $("#login").validate({

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
            "session[email]": {required: true, email: true},
            //"user[email]": {required: true, email: true, remote:"/users/check_email"},
            "session[password]": {required: true, minlength: 6},
            
        },
        errorPlacement: function(error, element) {
            //if (element.attr("name") == "user[department]" || element.attr("name") == "user[first_name]" ) {
            // error.insertBefore("#user_department");
            //} else {
            error.insertBefore(element);
            //error.appendTo( element.parent() );
            //}
        },
        messages: {
            "session[password]": {
                required: "Please type your password",
                //minlength: jQuery.format("At least {0} characters required!")
            },
            "session[email]": {
                required: "We need your email address to contact you",
                email: "Your email address must be in the format of TumID@tum.de"
            }
        }
    });
});

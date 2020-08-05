$(document).ready(function() {
    $('.search-autocomplete').select2({
        placeholder: 'Select an option',
        minimumInputLength: 5,
        ajax: {
            url: '/businesses',
            dataType: 'json',
            data: function (params) {
                var search_type = $('input[name="search_type"]:checked').val()
                var query = {
                    address: params.term,
                    search_type: search_type
                }
                return query
            },
            processResults: function (data) {
                var results = $.map(data, function(item, index) {
                    return {
                        id: index,
                        business_id: item.id,
                        user_id: item.user_id,
                        address: item.address,
                        place_id: item.place_id,
                        text: item.full_address,
                        disabled: item.user_id
                    }
                })
                return {
                    results: results
                }
            },
            deley: 500,
        },

        templateSelection: function (data, container) {
            $(data.element).attr('data-user_id', data.user_id);
            $(data.element).attr('data-address', data.address);
            $(data.element).attr('data-place_id', data.place_id);
            $(data.element).attr('data-business_id', data.business_id);
            return data.text;
        },
        templateResult: formatState
    });

    $('.search-autocomplete').on('select2:select', function (e) {
        var business = $('#address').find(':selected')
        $('#business_place_id').val(business.data('place_id'))
        $('#business_id').val(business.data('business_id'))
    });

    function formatState (state) {
        var icon = ''
        if (!state.business_id) {
            icon = 'fa-google'
        } else {
            icon = state.user_id ? 'fa-building text-danger' : 'fa-building'
        }
        var $state = $('<span><i class="fa ' + icon + '"></i>' + state.text + '</span>');
        return $state;
    };
})
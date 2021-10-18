function obfuscated_click_handler($links) {

    $links.forEach( $link => {

        $link.addEventListener('click', (e) => {
            e.preventDefault();

            //TODO: replace with toggle modal
            alert('hi stub click');
        });

    });

}

document.addEventListener('DOMContentLoaded', () => {

    const $links = Array.from( document.querySelectorAll('.obfuscated-link') );

    obfuscated_click_handler($links);

});

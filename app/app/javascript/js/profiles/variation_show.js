/*
* 'show more' toggle
*/
console.log("TOGGLE")

//onclick, unhide 10, readjust Number
window.abrepo = window.abrepo || {};

window.abrepo.variation_showmore = function() {
    let $variations = document.querySelectorAll('.variation.is-invisible');
    $variations.forEach( $variation => $variation.classList.replace('is-invisible', 'is-visible'));
    document.querySelector('.toggle').remove();
};

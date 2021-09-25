/*
 * shared/expvar_table handlers to toggle classes onClick
 */

function varViewClickHandler($rootDiv, vendor_id) {
    console.log("varViewClickHandler", vendor_id);

    //get all "child" dupe views
    const $variationViews = document
          .querySelectorAll(`[data-vendor="${vendor_id}"]`);

    $rootDiv.querySelectorAll(['i.fa-caret-right', 'i.fa-caret-down'])
        .forEach( $i => $i.classList.toggle('is-hidden'));

    $variationViews.forEach($v => $v.classList.toggle('is-hidden'));
    $rootDiv.querySelectorAll('.see-more')
        .forEach( $div => $div.classList.toggle('is-hidden'));;
};


function userSaveVariationClickHandler($div) {

    const url = '/saved';

    const authenticity_token = document
          .querySelector('meta[name="csrf-token"]')
          .getAttribute("content");

    const data = {
        authenticity_token,
        id: $div.dataset.variationId,
    };

    window.fetch(url, {
        method: 'POST',
        headers:  {
            "Accept": "application/json",
            "Content-Type": "application/json"
        },
        body: JSON.stringify(data)

    }).then(res => {
        if (res.ok) return res.json();
        throw new Error('[UserSaveVariation] error');
    }).then(resJSON => {
        ///sucess
        console.log(resJSON);

    }).catch(e => {
        console.error(e);
    });
}

document.addEventListener('DOMContentLoaded', () => {

    /* attach click handlers to 'root' variation-view */
    const $variationRoots = document
          .querySelectorAll('[data-root-vendor-id]')
          .forEach( $div => {

              const vendor_id = $div.dataset.rootVendorId;

              $div.addEventListener('click', (e) => {

                  //*want* to follow link, and not run js
                  if(e.target.tagName != "A") {
                      varViewClickHandler($div, vendor_id);
                  }
              });
          });

    /* attach save click handlers */
    const $user_saves = document
          .querySelectorAll('button.user-save-variations')
          .forEach( $div => {
              $div.addEventListener('click', (e) => {
                  userSaveVariationClickHandler($div);
              });
    });

});

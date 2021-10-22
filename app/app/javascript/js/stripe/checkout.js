/*
 * main stripe checkout session code
 *
 * expects a data-div "#stripe-data" that contains server-side
 * generated stripe keys, request url (given new user, or registered
 * user sans subscription)
 *
 * 1. builds payload (w/ credentials or not, stripe plan ids, tec)
 * 2.  hits checkout_user_create or checkout_session path
 * to get a stripe session id
 * 3. redirects user to stripe for payment info.
 */


const renderErrors = (messages) => {

    const $li = messages.map( message => {
        return ['<li>', message, '</li>'].join('');
    }).join('');

    const list = ['<ul class="mt-0 l-0">', $li, '</ul>'].join('');
    const $errorDiv = document.querySelector('#error_explanation');
    if($errorDiv) {
        $errorDiv.className = "notification is-danger is-light";
        $errorDiv.innerHTML = list;
    } else {
        console.log(messages);
    }

};

const _getUser = () => {

    const $form = document.querySelector('#new_user');
    if (!$form) return null;

    const formData = new FormData($form);

    return {
        email: formData.get('user[email]'),
        password: formData.get('user[password]')
    };
};

const buildPayload = (price_id, price_key) =>  {

    const user = _getUser();

    return {
        user,
        data:{ price_id, price_key }
    };
};


const createCheckoutSession = (url, csrf_token, payload) => {
    return fetch(url, {
        method: "POST",
        headers: {
            "Content-Type": "application/json",
            "X-CSRF-Token": csrf_token
        },
        body: JSON.stringify(payload)
    }).then( (result) => {
        return result.json();
    });
};


const subscribeClickHandler = (e, $stripedata) => {

    e.preventDefault();

    const { stripeKey, priceKey, priceId, url, csrfToken } = {...$stripedata};

    const stripe = Stripe(stripeKey);
    const payload = buildPayload(priceId, priceKey);

    createCheckoutSession(url, csrfToken, payload)
        .then( data => {

            if (data.user.ok && data.stripe.ok) {
                return stripe.redirectToCheckout({ sessionId: data.stripe.sessionId });
            }

            if (data.user.ok && !data.stripe.ok) {
                return renderErrors(data.stripe.errors.messages);
            }

            if( !data.user.ok) {
                return renderErrors(data.user.errors.messages);
            }

            return null;
        });

};


document.addEventListener('DOMContentLoaded', () => {

    const $subscribes = document.querySelectorAll('.checkout');
    if(!$subscribes.length) return;

    $subscribes.forEach( $subscribe => {

        const $stripedata = $subscribe.dataset;
        if (!$stripedata) return;

        $subscribe.addEventListener('click',
                                    (e) => subscribeClickHandler(e, $stripedata) );
    });
});

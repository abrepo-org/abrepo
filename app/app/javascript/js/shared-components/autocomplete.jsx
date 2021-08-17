import React, { useState, useEffect } from 'react';

/*
 * InputTextField
 * tags, industry autocomplete
 *
 */
export const InputTextField = (props) => {

    const baseURL = props.$component.dataset.baseurl;
    const destination = props.$component.dataset.destination;

    const changeHandler = (e) => {

        const event = new CustomEvent('fetch', {detail: {status: true}});
        document.body.dispatchEvent(event);

        const response = fetch(`${baseURL}?query=${e.target.value}&partial=true`)
            .then(res => res.text())
            .then( res => {

                const $destination = document.querySelector(destination);

                //update content
                if($destination) {
                    $destination.outerHTML = res
                }

                //update url
                if (history.pushState) {
                    let searchParams = new URLSearchParams(window.location.search);
                    searchParams.set('query', e.target.value);
                    let newurl = [
                        window.location.origin,
                        window.location.pathname,
                        '?',
                        searchParams.toString()
                    ].join("");

                    window.history.pushState({path: newurl}, '', newurl);
                }

                //send fetch enable
                const event = new CustomEvent('fetch', {detail: {status: false}});
                document.body.dispatchEvent(event);
            });
    };

    props.$component.addEventListener("input", changeHandler);

    return null;
};



/*
 * InputSubmit
 */

export const InputSubmit = (props) => {

    const fetchListener = (e) => {
        if(e.detail && e.detail.status) {
            props.$component.disabled = true
            return
        }

        props.$component.disabled = false
    };


    document.body.addEventListener('fetch', fetchListener);

    return null;
};

export default { InputTextField, InputSubmit };

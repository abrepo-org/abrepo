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

        const response = fetch(`${baseURL}?query=${e.target.value}&partial=true`)
            .then(res => res.text())
            .then( res => {

                const $destination = document.querySelector(destination);

                if($destination) {
                    $destination.outerHTML = res
                }
            });
    };

    props.$component.addEventListener("input", changeHandler);

    return null;
};

export default { InputTextField };

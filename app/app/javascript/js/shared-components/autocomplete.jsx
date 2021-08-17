import React, { useState, useEffect } from 'react';

export const Test = (props) => {

    const changeHandler = (e) => {
        console.log("hi", e.target.value);

        const $ulTags = document.querySelector('ul.tags');

        const response = fetch(`/tags?query=${e.target.value}&partial=true`)
            .then(res => res.text())
            .then( res => $ulTags.outerHTML = res );
    };

    props.tag.addEventListener("input", changeHandler);

    return null;
};

export default Test;

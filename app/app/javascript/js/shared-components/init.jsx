import React from 'react';
import ReactDOM from 'react-dom';

import Test from './autocomplete.jsx';

/*
 * example for code-splitting
 * have some kind of class name indicator ".shared-component .<type>"
 * use dataset as init params
 * to indicate decoration
 */

document.addEventListener('DOMContentLoaded', () => {

    const $tags = Array.from( document.getElementsByClassName('tag') );
    $tags.map( $tag => {
        
        ReactDOM.render(
            <Test dataset={$tag.dataset} />,
            $tag
        );
    });


});

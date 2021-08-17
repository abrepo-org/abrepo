import React from 'react';
import ReactDOM from 'react-dom';

import { InputTextField, InputSubmit } from './autocomplete.jsx';

/*
 * example for code-splitting
 * have some kind of class name indicator ".shared-component .<type>"
 * use dataset as init params
 * to indicate decoration
 */

document.addEventListener('DOMContentLoaded', () => {

    const $components = Array
          .from( document.getElementsByClassName('component-input-textfield-autocomplete') );

    $components.map( ($component, i) => {

        ReactDOM.render(
            <InputTextField $component={$component} />,
            $component.insertAdjacentElement('beforebegin', document.createElement('div'))
        );
    });

    const $submits = Array
          .from(document.getElementsByClassName('component-input-submit-autocomplete'));

    $submits.map( $submit => {
        ReactDOM.render(
            <InputSubmit $component={$submit} />,
            $submit.insertAdjacentElement('beforebegin', document.createElement('div'))
        );
    });

});

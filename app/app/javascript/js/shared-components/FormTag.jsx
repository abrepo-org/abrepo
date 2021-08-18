import React, { useState, useEffect } from 'react';
import { InputTextAutoComplete } from './InputTextAutoComplete.jsx';
import { updateURL } from './URLUpdater.js';

export const FormTag = (props) => {

    return(
        <form id="tag-filter"
              className="is-flex"
              action={props.baseURL}
              acceptCharset="UTF-8"
              method="get">

            <input name="utf8" type="hidden" value="✓" />

            <InputTextAutoComplete updateURL={updateURL} { ...props } />
        </form>
    );

};

export default { FormTag };

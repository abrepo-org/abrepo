import React, { useState, useEffect } from 'react';
import { InputTextAutoComplete } from './InputTextAutoComplete.jsx';
import { Button } from './Button.jsx';
import { updateURL } from './URLUpdater.js';

export const FormTag = (props) => {

    const [inputBusy, setInputBusy] = useState(false);

    return(
        <form id="tag-filter"
              className="is-flex"
              action={props.baseURL}
              acceptCharset="UTF-8"
              method="get">

            <input name="utf8" type="hidden" value="✓" />

            <InputTextAutoComplete updateURL={updateURL}
                                   setInputBusy={setInputBusy}
                                   { ...props } />

            <Button disabled={inputBusy} />
        </form>
    );

};

export default { FormTag };

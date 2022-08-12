import React, { useState, useEffect } from 'react';
import { TagInputTextAutoComplete } from './TagInputTextAutoComplete.jsx';
import { Button } from './Button.jsx';

export const TagForm = (props) => {

    const [inputBusy, setInputBusy] = useState(false);

    return(
        <form id="tag-filter"
              className="is-flex"
              action={props.baseURL}
              acceptCharset="UTF-8"
              method="get">

            <TagInputTextAutoComplete setInputBusy={setInputBusy}
                                      { ...props } />

            <Button disabled={inputBusy} />
        </form>
    );

};

export default { TagForm };

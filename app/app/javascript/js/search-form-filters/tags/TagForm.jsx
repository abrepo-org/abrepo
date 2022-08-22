import React, { useState, useEffect } from 'react';
import { Button } from '../Button.jsx';
import { TagInputTextAutoComplete } from './TagInputTextAutoComplete.jsx';


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

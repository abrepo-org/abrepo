import React, { useState, useEffect } from 'react';
import { InputTextAutoComplete } from './InputTextAutoComplete.jsx';
import { Button } from './Button.jsx';

export const SearchForm = (props) => {

    const baseURL = props.baseURL;

    const [inputBusy, setInputBusy] = useState(false);

    let searchParams = new URLSearchParams(window.location.search);
    const [query, setQuery] = useState( (searchParams && searchParams.get("query")) || '' );

    return(
        <form id="search-form"
              className="is-flex"
              action={baseURL}
              acceptCharset="UTF-8"
              method="get">
            <input name="utf8" type="hidden" value="✓" />

            <InputTextAutoComplete
                setInputBusy={setInputBusy}
                {...props} />

            <Button disabled={inputBusy} />


            <div className="field">

                <div className="dropdown is-active">
                    <div className="dropdown-trigger">
                        <button className="button" aria-haspopup="true" aria-controls="dropdown-menu-tag">
                            <span>Tag</span>
                            <span className="icon is-small">
                                <i className="fas fa-angle-down" aria-hidden="true"></i>
                            </span>
                        </button>
                    </div>

                    <div className="dropdown-menu" id="dropdown-menu-tag" role="menu">
                        <div className="dropdown-content">

                            <div className="dropdown-item">
                                <p><strong>Tags</strong></p>
                                <InputTextAutoComplete
                                    baseURL='/tags'
                                    destination="#tag-destination > ul"
                                    placeholder="Filter Tags"
                                />
                                <p id="tag-destination">
                                    <ul></ul>
                                </p>
                            </div>

                            <hr className="dropdown-divider" />
                            <div className="dropdown-item">
                                <p>You simply need to use a <code>&lt;div&gt;</code> instead.</p>
                            </div>

                            <hr className="dropdown-divider" />
                            <a href="#" className="dropdown-item">

                            </a>
                        </div>
                    </div>

                </div>
            </div>
        </form>
    );
};

export default SearchForm;

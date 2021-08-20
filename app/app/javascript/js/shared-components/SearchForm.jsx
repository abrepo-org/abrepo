import React, { useState, useEffect } from 'react';
import { InputTextAutoComplete } from './InputTextAutoComplete.jsx';
import { SearchInputTextAutoComplete } from './SearchInputTextAutoComplete.jsx';
import { Button } from './Button.jsx';
import { AutoCompleteTag } from './AutoCompleteTag.jsx';

export const SearchForm = (props) => {

    const [formActionURL, setFormActionURL]  = useState(props.baseURL);
    const [inputBusy, setInputBusy] = useState(false);

    let searchParams = new URLSearchParams(window.location.search);
    //query
    const [query, setQuery] = useState( (searchParams && searchParams.get("query")) || '' );

    //tags
    const [selectedTags, setSelectedTags] = useState((searchParams && searchParams.getAll("tags[]")) || '' )
    const [autocompleteTags, setAutocompleteTags] = useState([]);
    const [resetTrigger, setResetTrigger] = useState(0);


    const addTag = (tag) => {
        setSelectedTags(selectedTags => [...selectedTags, tag])
    };

    const removeTag = (tag) => {
        setSelectedTags(selectedTags => selectedTags.filter(t => t != tag))
    };

    const clearSelected = () => {
        setAutocompleteTags([]) //clear auto complete list
        setResetTrigger(resetTrigger+1)       //trigger useEffect hook to clear input value
    };

    return(
        <form id="search-form"
              className="is-flex"
              action={formActionURL}
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

                                <SearchInputTextAutoComplete
                                    baseURL='/tags.json'
                                    queryField="tags[]"
                                    resetTrigger={resetTrigger}
                                    setAutoCompleteResults={setAutocompleteTags}
                                    selectedTags={selectedTags}
                                    removeTag={removeTag}
                                    placeholder="Filter Tags"
                                />

                                <div id="tag-destination">

                                    <ul className="tags">

                                        {
                                            autocompleteTags.map(tag => {
                                                return (<AutoCompleteTag key={tag}
                                                                         tag={tag}
                                                                         clearSelected={clearSelected}
                                                                         addTag={addTag} />);
                                            })
                                        }

                                    </ul>

                                </div>
                            </div>

                            <div className="dropdown-item">
                                <button type="submit" className="button is-small">
                                    Apply Filters
                                </button>
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

import React, { useState, useEffect } from 'react';
import { SearchInputTextAutoComplete } from './SearchInputTextAutoComplete.jsx';
import { AutoCompleteTag } from './AutoCompleteTag.jsx';

export const ProfileSearchFilter = (props) => {

    const [selectedTags, setSelectedTags] = useState( props.selectedTags );
    const [autocompleteTags, setAutocompleteTags] = useState([]);
    const [autocompleteTotals, setAutocompleteTotals]  = useState(false);
    const [resetTrigger, setResetTrigger] = useState(0);

    const addTag = (tag) => {
        setSelectedTags(selectedTags => [...selectedTags, tag]);
        setResetTrigger(resetTrigger+1);
    };

    const removeTag = (tag) => {
        setSelectedTags(selectedTags => selectedTags.filter(t => t != tag));
        setResetTrigger(resetTrigger+1);
    };

    const clearSelected = (selectedTag) => {

        //filter auto complete list
        setAutocompleteTags(autocompleteTags.filter( tag => tag != selectedTag));
        setResetTrigger(resetTrigger+1);   //trigger useEffect hook to clear input value
    };

    //open close Tag dropdown
    const openCloseClickHandler = (e) => {
        e.preventDefault();
        const update = {};
        update[props.id] = !props.filterOpenState[props.id];

        //close All
        Object.keys(props.filterOpenState).forEach( key => {
            props.filterOpenState[key] = false;
        });

        //toggle individual (open or close)
        props.setFilterOpenState( {...props.filterOpenState, ...update });
    };

    const ApplyFiltersClickHandler = (e) => {
        props.setSelectedTags(selectedTags)
    };

    return(

        <div className="field mr-2">

            <div className={`dropdown ${props.filterOpenState[props.id] ? 'is-active' : ''}`}>
                <div className="dropdown-trigger">
                    <button className="button is-small"
                            type="button"
                            onClick={(e) => openCloseClickHandler(e)}
                            aria-haspopup="true"
                            aria-controls="dropdown-menu-tag">
                        <span>Filter by {props.name}</span>
                        <span className="icon is-small">
                            <i className="fas fa-angle-down" aria-hidden="true"></i>
                        </span>
                    </button>
                </div>

                <div className="dropdown-menu" id="dropdown-menu-tag" role="menu">
                    <div className="dropdown-content">

                        <div className="dropdown-item">

                            <p className="is-flex is-justify-content-space-between">
                                <span>
                                    <strong>Filter by {props.name}</strong>
                                </span>
                                <a href="#"
                                   class="delete"
                                   onClick={(e) => openCloseClickHandler(e)}>
                                </a>

                            </p>

                            {
                                /* list of selected tags */
                            }
                            <SearchInputTextAutoComplete
                                baseURL={props.baseURL}
                                queryField={props.queryField}
                                resetTrigger={resetTrigger}
                                setAutoCompleteResults={setAutocompleteTags}
                                setAutoCompleteTotals={setAutocompleteTotals}
                                selectedTags={selectedTags}
                                removeTag={removeTag}
                                placeholder={props.placeholder}
                            />

                            {
                                /* tag list - possible tags (not selected) */
                            }
                            <div id="tag-destination">

                                <ul className="tags ml-0 is-inline">

                                    {
                                        autocompleteTags.map( (tag, i) => {
                                            return (<AutoCompleteTag key={tag}
                                                                     tag={tag}
                                                                     i={i}

                                                                     clearSelected={clearSelected}
                                                                     addTag={addTag} />);
                                        })
                                    }

                                </ul>


                                {!!autocompleteTotals &&
                                 <div className="ml-1 mt-2">
                                     <a href={`/${props.name.toLowerCase()}/`}>
                                         {`See All ${props.name}`}
                                         {autocompleteTotals ? ` (${autocompleteTotals})` : '' }
                                     </a>
                                 </div>
                                }

                            </div>
                        </div>

                        <hr className="dropdown-divider" />
                        <div className="dropdown-item">
                            <button
                                onClick={(e) => ApplyFiltersClickHandler(e)}
                                className="button is-small">
                                Apply Filters
                            </button>
                        </div>

                    </div>
                </div>

            </div>
        </div>
    );

};

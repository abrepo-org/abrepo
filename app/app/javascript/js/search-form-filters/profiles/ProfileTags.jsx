import React, { useState, useEffect } from 'react';

export const ProfileTags = (props) => {

    const allTags = [...props.selectedTags, ...props.selectedIndustries];

    return(
        <div>
            {allTags && allTags.map(selectedTag => {

                 const otherTags = allTags.filter( t => t != selectedTag );

                 const _formQuery = props
                     .buildFormQuery(props.selectedQuery,
                                     otherTags.filter(t => props.selectedTags.includes(t)),
                                     otherTags.filter(t => props.selectedIndustries.includes(t)))
                     .replaceAll(" ", "+");

                 const tagClass = props.selectedTags.includes(selectedTag) ?
                                  'is-info' : 'is-warning';

                 const href = _formQuery ?
                              `${props.baseURL}?query=${_formQuery}` :
                              props.baseURL;

                 return (
                     <span key={selectedTag}
                           className="tags is-inline-flex is-flex-wrap-nowrap has-addons mb-0 mr-2">
                         <span className={`tag ${tagClass} mb-0`}>
                             {selectedTag}
                         </span>
                         <a className="tag is-delete mb-0"
                            href={href}></a>
                     </span>
                 );
             })
            }
        </div>
    );

};

export default { ProfileTags };

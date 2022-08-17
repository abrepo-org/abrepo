import React from 'react';
import ReactDOM from 'react-dom';

export default class ActionContainer extends React.Component {

    constructor(props) {
        super(props);
        console.log("ActionContainer");
    }
    /*

       Behavior:

       if only default action, "null action" row is hidden - no
       discernable action.

       if there is an action, set action toggle on/off on the max
       bbox renderable
       e.g null 1 diff vs A2 - 3 diffs, set toggle on A2

       What if A4, A3, A2, etc.?
       a. Filter out empty bbox
       b. set default toggle on max (rest are off)

       View:
       Toggle [on|off| | Action | Selector | Description

       TODO: Action selector highlights are like bbox blue; maybe fickker?
       This would need abrender dims

       ----

       on mobile, stack
       this.props.action &&
       const action = {
       id: 123,
       type: "CLICK",
       selector: ".xyz",
       url: "https://www.optimizely.com"
       }

     */



    render() {

        const isOnlyNullAction = this.props.data.actions
                                     .every( action => action.actionType == null);

        if (isOnlyNullAction) return null;

        return(

            <table className="table variation-action">
                <thead>
                    <tr>
                        <th>Display</th>
                        <th>Selector</th>
                        <th>Description</th>
                    </tr>
                </thead>
                <tbody>
                    {this.props.data.actions.map( action =>  {

                         const isChecked = (action.id == this.props.activeAction.id);
                         const isHover = (action.id == this.props.bboxHoverId);

                         //TODO: sync color with ActionBoundingBox
                         const activeStyle = {
                             background: 'rgb(255, 239, 213)'
                         }

                         //hover style settings
                         const lineWidth = 3;
                         const hoverStyle= {
                             background: 'rgb(255, 239, 213)'
                             //outline: `${lineWidth}px solid rgb(255, 239, 213)`,
                         }

                         return(
                             <tr key={action.id} style={isHover ? hoverStyle : {}}>
                                 <td className="has-text-centered">
                                     <div className="control">
                                         <input type="radio"
                                                name="action"
                                                value={action.id}
                                                defaultChecked={isChecked}
                                                onChange={(e) => this.props.actionSelectHandler(e)}
                                         />
                                     </div>
                                 </td>

                                 <td>
                                     { action.selectorDisplayName || action.selector || '-' }
                                 </td>

                                 <td>
                                     {
                                         action.description ||
                                         (action.actionType == null ? 'Original Page' : '')
                                     }
                                 </td>
                             </tr>
                         )
                     })
                    }
                </tbody>
            </table>

        );

    }
}

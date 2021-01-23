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

    scrollStickyHandler(e) {
        console.log("scrollSticky", e)
        //get navbar dim
        //get scrolled boundingbox y value
        //check if scroll y is below boundingbox y
        //set it to pos fixed

    }

    componentDidMount() {
        window.addEventListener('scroll', this.scrollStickyHandler.bind(this));
    }

    componentWillUnmount() {
        window.addEventListener('scroll', this.scrollStickyHandler);
    }

    render() {

        return(

            <table className="table is-fullwidth variation-action">
                <thead>
                    <tr>
                        <th>Show</th>
                        <th>Action</th>
                        <th>Selector</th>
                        <th>URL</th>
                    </tr>
                </thead>
                <tbody>
                    {this.props.data.actions.map( action =>  {

                         const isChecked = (action.id == this.props.activeAction.id)

                         return(
                             <tr key={action.id}>
                                 <td>
                                     <div className="control">
                                         <input type="radio"
                                                name="action"
                                                value={action.id}
                                                defaultChecked={isChecked}
                                                onChange={(e) => this.props.actionSelectHandler(e)}
                                         />
                                     </div>
                                 </td>
                                 <td> { action.actionType } </td>
                                 <td> { action.selector } </td>
                                 <td> { action.url } </td>
                             </tr>
                         )
                     })
                    }
                </tbody>
            </table>

        );

    }
}
